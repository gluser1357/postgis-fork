/**********************************************************************
 *
 * PostGIS - Spatial Types for PostgreSQL
 *
 * http://postgis.net
 *
 * Copyright (C) 2011      Sandro Santilli <strk@kbt.io>
 * Copyright (C) 2009-2011 Paul Ramsey <pramsey@cleverelephant.ca>
 * Copyright (C) 2008      Mark Cave-Ayland <mark.cave-ayland@siriusit.co.uk>
 * Copyright (C) 2004-2007 Refractions Research Inc.
 *
 * This is free software; you can redistribute and/or modify it under
 * the terms of the GNU General Public Licence. See the COPYING file.
 *
 **********************************************************************/

#include <postgres.h>
#include <fmgr.h>
#include <miscadmin.h>
#include <access/heapam.h>
#include <access/htup.h>
#include <access/htup_details.h>
#include <access/skey.h>
#include <access/genam.h>
#include <access/sysattr.h>
#include <catalog/indexing.h>
#include <executor/spi.h>
#include <utils/builtins.h>
#include <utils/guc.h>
#include <utils/guc_tables.h>
#include <utils/fmgroids.h>
#include <catalog/namespace.h>
#include <catalog/pg_extension.h>
#include <commands/extension.h>

#include "../postgis_config.h"

#include <utils/regproc.h>

#include "liblwgeom.h"
#include "lwgeom_pg.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#define PGC_ERRMSG_MAXLEN 2048 //256

/****************************************************************************************/
/* Global to hold all the run-time constants */

postgisConstants *POSTGIS_CONSTANTS = NULL;

/* Utility call to lookup type oid given name and nspoid */
static Oid TypenameNspGetTypid(const char *typname, Oid nsp_oid)
{
	return GetSysCacheOid2(TYPENAMENSP,
	                       Anum_pg_type_oid,
	                       PointerGetDatum(typname),
	                       ObjectIdGetDatum(nsp_oid));
}

/*
 * get_extension_schema - given an extension OID, fetch its extnamespace
 *
 * Returns InvalidOid if no such extension.
 */
static Oid
postgis_get_extension_schema(Oid ext_oid)
{
    Oid         result;
    SysScanDesc scandesc;
    HeapTuple   tuple;
    ScanKeyData entry[1];

    Relation rel = table_open(ExtensionRelationId, AccessShareLock);
    ScanKeyInit(&entry[0],
    	Anum_pg_extension_oid,
        BTEqualStrategyNumber, F_OIDEQ,
        ObjectIdGetDatum(ext_oid));

    scandesc = systable_beginscan(rel, ExtensionOidIndexId, true,
                                  NULL, 1, entry);

    tuple = systable_getnext(scandesc);

    /* We assume that there can be at most one matching tuple */
    if (HeapTupleIsValid(tuple))
        result = ((Form_pg_extension) GETSTRUCT(tuple))->extnamespace;
    else
        result = InvalidOid;

    systable_endscan(scandesc);

    table_close(rel, AccessShareLock);

    return result;
}

static Oid
postgis_get_full_version_schema()
{
	const char* query =  "SELECT pronamespace "
		" FROM pg_catalog.pg_proc "
		" WHERE proname = 'postgis_full_version'";
	int spi_result;
	Oid funcNameSpaceOid;

	if (SPI_OK_CONNECT != SPI_connect())
	{
		elog(ERROR, "%s: could not connect to SPI manager", __func__);
		return InvalidOid;
	}

	/* Execute the query, noting the readonly status of this SQL */
	spi_result = SPI_execute(query, true, 0);

	if (spi_result != SPI_OK_SELECT || SPI_tuptable == NULL){
		elog(ERROR, "%s: error executing query %d", __func__, spi_result);
		SPI_finish();
		return InvalidOid;
	}

	/* Read back the OID of the function namespace, only if one result returned
	  If more than one, then this install is f..cked.
		If 0 then postgis is not installed at all */
	if (SPI_processed == 1)
	{
		TupleDesc tupdesc;
		SPITupleTable *tuptable = SPI_tuptable;
		HeapTuple tuple;

		tupdesc = SPI_tuptable->tupdesc;
		tuptable = SPI_tuptable;
		tuple = tuptable->vals[0];
		funcNameSpaceOid = atoi(SPI_getvalue(tuple, tupdesc, 1));

		if (SPI_tuptable) SPI_freetuptable(tuptable);
		SPI_finish();
	}
	else
	{
		elog(ERROR, "Cannot determine install schema of postgis_full_version function.");
		SPI_finish();
		return InvalidOid;
	}

	return funcNameSpaceOid;
}


/* Cache type lookups in per-session location */
static postgisConstants *
getPostgisConstants()
{
	Oid nsp_oid = InvalidOid;
	Oid ext_oid = get_extension_oid("postgis", true);
	if (ext_oid != InvalidOid)
	{
		nsp_oid = postgis_get_extension_schema(ext_oid);
	}
	else
	{
		nsp_oid = postgis_get_full_version_schema();
	}

	/* early exit if we cannot lookup nsp_name, cf #4067 */
	if (nsp_oid == InvalidOid)
		elog(ERROR, "Unable to determine 'postgis' install schema");

	/* Put constants cache in a child of the CacheContext */
	MemoryContext context = AllocSetContextCreate(
	    CacheMemoryContext,
	    "PostGIS Constants Context",
	    ALLOCSET_SMALL_SIZES);

	/* Allocate in the CacheContext so we don't lose this at the end of the statement */
	postgisConstants* constants = MemoryContextAlloc(context, sizeof(postgisConstants));

	/* Calculate fully qualified name of 'spatial_ref_sys' */
	char *nsp_name = get_namespace_name(nsp_oid);
	constants->install_nsp_oid = nsp_oid;
	constants->install_nsp = MemoryContextStrdup(CacheMemoryContext, nsp_name);

	char *spatial_ref_sys_fullpath = quote_qualified_identifier(nsp_name, "spatial_ref_sys");
	constants->spatial_ref_sys = MemoryContextStrdup(CacheMemoryContext, spatial_ref_sys_fullpath);
	elog(DEBUG4, "%s: Spatial ref sys qualified as %s", __func__, spatial_ref_sys_fullpath);
	pfree(nsp_name);
	pfree(spatial_ref_sys_fullpath);

	/* Lookup all the type names in the context of the install schema */
	constants->geometry_oid = TypenameNspGetTypid("geometry", nsp_oid);
	constants->geography_oid = TypenameNspGetTypid("geography", nsp_oid);
	constants->box2df_oid = TypenameNspGetTypid("box2df", nsp_oid);
	constants->box3d_oid = TypenameNspGetTypid("box3d", nsp_oid);
	constants->gidx_oid = TypenameNspGetTypid("gidx", nsp_oid);
	constants->raster_oid = TypenameNspGetTypid("raster", nsp_oid);

	/* Done */
	return constants;
}

Oid
postgis_oid(postgisType typ)
{
	/* Use a schema qualified, cached lookup if we can */
	postgisConstants *cnsts = POSTGIS_CONSTANTS;
	if (cnsts)
	{
		switch (typ)
		{
			case GEOMETRYOID:
				return cnsts->geometry_oid;
			case GEOGRAPHYOID:
				return cnsts->geography_oid;
			case BOX3DOID:
				return cnsts->box3d_oid;
			case BOX2DFOID:
				return cnsts->box2df_oid;
			case GIDXOID:
				return cnsts->gidx_oid;
			case RASTEROID:
				return cnsts->raster_oid;
			case POSTGISNSPOID:
				return cnsts->install_nsp_oid;
			default:
				return InvalidOid;
		}
	}
	/* Fall back to a bare lookup and hope the type in is */
	/* the search_path */
	else
	{
		switch (typ)
		{
			case GEOMETRYOID:
				return TypenameGetTypid("geometry");
			case GEOGRAPHYOID:
				return TypenameGetTypid("geography");
			case BOX3DOID:
				return TypenameGetTypid("box3d");
			case BOX2DFOID:
				return TypenameGetTypid("box2df");
			case GIDXOID:
				return TypenameGetTypid("gidx");
			case RASTEROID:
				return TypenameGetTypid("raster");
			default:
				return InvalidOid;
		}
	}
}

void
postgis_initialize_cache()
{
	/* Cache the info if we don't already have it */
	if (!POSTGIS_CONSTANTS)
		POSTGIS_CONSTANTS = getPostgisConstants();
}

const char *
postgis_spatial_ref_sys()
{
	if (!POSTGIS_CONSTANTS)
		return NULL;
	return POSTGIS_CONSTANTS->spatial_ref_sys;
}

/****************************************************************************************/


/*
 * Error message parsing functions
 *
 * Produces nicely formatted messages for parser/unparser errors with optional HINT
 */

void
pg_parser_errhint(LWGEOM_PARSER_RESULT *lwg_parser_result)
{
	char *hintbuffer;

	/* Only display the parser position if the location is > 0; this provides a nicer output when the first token
	   within the input stream cannot be matched */
	if (lwg_parser_result->errlocation > 0)
	{
		/* Return a copy of the input string start truncated
		 * at the error location */
		hintbuffer = lwmessage_truncate(
			(char *)lwg_parser_result->wkinput, 0,
			lwg_parser_result->errlocation - 1, 40, 0);

		ereport(ERROR,
		        (errmsg("%s", lwg_parser_result->message),
		         errhint("\"%s\" <-- parse error at position %d within geometry", hintbuffer, lwg_parser_result->errlocation))
		       );
	}
	else
	{
		ereport(ERROR,
		        (errmsg("%s", lwg_parser_result->message),
		         errhint("You must specify a valid OGC WKT geometry type such as POINT, LINESTRING or POLYGON"))
		       );
	}
}

void
pg_unparser_errhint(LWGEOM_UNPARSER_RESULT *lwg_unparser_result)
{
	/* For the unparser simply output the error message without any associated HINT */
	elog(ERROR, "%s", lwg_unparser_result->message);
}

static void *
pg_alloc(size_t size)
{
	void * result;

	CHECK_FOR_INTERRUPTS(); /* give interrupter a chance */

	POSTGIS_DEBUGF(5, "  pg_alloc(%d) called", (int)size);

	result = palloc(size);

	POSTGIS_DEBUGF(5, "  pg_alloc(%d) returning %p", (int)size, result);

	return result;
}

static void *
pg_realloc(void *mem, size_t size)
{
	void * result;

	CHECK_FOR_INTERRUPTS(); /* give interrupter a chance */

	POSTGIS_DEBUGF(5, "  pg_realloc(%p, %d) called", mem, (int)size);

	result = repalloc(mem, size);

	POSTGIS_DEBUGF(5, "  pg_realloc(%p, %d) returning %p", mem, (int)size, result);

	return result;
}

static void
pg_free(void *ptr)
{
	pfree(ptr);
}

static void
pg_error(const char *fmt, va_list ap)
{
	char errmsg[PGC_ERRMSG_MAXLEN+1];

	vsnprintf (errmsg, PGC_ERRMSG_MAXLEN, fmt, ap);

	errmsg[PGC_ERRMSG_MAXLEN]='\0';
	ereport(ERROR, (errmsg_internal("%s", errmsg)));
}

static void
pg_warning(const char *fmt, va_list ap)
{
	char errmsg[PGC_ERRMSG_MAXLEN+1];

	vsnprintf (errmsg, PGC_ERRMSG_MAXLEN, fmt, ap);

	errmsg[PGC_ERRMSG_MAXLEN]='\0';
	ereport(WARNING, (errmsg_internal("%s", errmsg)));
}

static void
pg_notice(const char *fmt, va_list ap)
{
	char errmsg[PGC_ERRMSG_MAXLEN+1];

	vsnprintf (errmsg, PGC_ERRMSG_MAXLEN, fmt, ap);

	errmsg[PGC_ERRMSG_MAXLEN]='\0';
	ereport(NOTICE, (errmsg_internal("%s", errmsg)));
}

static void
pg_debug(int level, const char *fmt, va_list ap)
{
	char errmsg[PGC_ERRMSG_MAXLEN+1];
	vsnprintf (errmsg, PGC_ERRMSG_MAXLEN, fmt, ap);
	errmsg[PGC_ERRMSG_MAXLEN]='\0';
	int pglevel[6] = {NOTICE, DEBUG1, DEBUG2, DEBUG3, DEBUG4, DEBUG5};

	if ( level >= 0 && level <= 5 )
		ereport(pglevel[level], (errmsg_internal("%s", errmsg)));
	else
		ereport(DEBUG5, (errmsg_internal("%s", errmsg)));
}

void
pg_install_lwgeom_handlers(void)
{
	/* install PostgreSQL handlers */
	lwgeom_set_handlers(pg_alloc, pg_realloc, pg_free, pg_error, pg_notice);
	/*
	If you want to try with malloc:
	lwgeom_set_handlers(NULL, NULL, NULL, pg_error, pg_notice);
	*/
	lwgeom_set_debuglogger(pg_debug);
}

/**
* Utility method to call the serialization and then set the
* PgSQL varsize header appropriately with the serialized size.
*/
GSERIALIZED* geography_serialize(LWGEOM *lwgeom)
{
	size_t ret_size;
	GSERIALIZED *g;
	/** force to geodetic in case it's not **/
	lwgeom_set_geodetic(lwgeom, true);

	g = gserialized_from_lwgeom(lwgeom,  &ret_size);
	SET_VARSIZE(g, ret_size);
	return g;
}


/**
* Utility method to call the serialization and then set the
* PgSQL varsize header appropriately with the serialized size.
*/
GSERIALIZED* geometry_serialize(LWGEOM *lwgeom)
{
	size_t ret_size;
	GSERIALIZED *g;

	g = gserialized_from_lwgeom(lwgeom, &ret_size);
	SET_VARSIZE(g, ret_size);
	return g;
}

void
lwpgnotice(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);

  pg_notice(fmt, ap);

	va_end(ap);
}

void
lwpgwarning(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);

  pg_warning(fmt, ap);

	va_end(ap);
}

void
lwpgerror(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);

  pg_error(fmt, ap);

	va_end(ap);
}


/*
 * the bare comparison function for GUC names
 */
int
postgis_guc_name_compare(const char *namea, const char *nameb)
{
	/*
	 * The temptation to use strcasecmp() here must be resisted, because the
	 * array ordering has to remain stable across setlocale() calls. So, build
	 * our own with a simple ASCII-only downcasing.
	 */
	while (*namea && *nameb)
	{
		char		cha = *namea++;
		char		chb = *nameb++;

		if (cha >= 'A' && cha <= 'Z')
			cha += 'a' - 'A';
		if (chb >= 'A' && chb <= 'Z')
			chb += 'a' - 'A';
		if (cha != chb)
			return cha - chb;
	}
	if (*namea)
		return 1;				/* a is longer */
	if (*nameb)
		return -1;				/* b is longer */
	return 0;
}

/*
 * comparator for qsorting and bsearching guc_variables array
 */
int
postgis_guc_var_compare(const void *a, const void *b)
{
	const struct config_generic *confa = *(struct config_generic * const *) a;
	const struct config_generic *confb = *(struct config_generic * const *) b;

	return postgis_guc_name_compare(confa->name, confb->name);
}

/*
* This is copied from the top half of the find_option function
* in postgresql's guc.c. We search the guc_variables for our option.
* Then we make sure it's not a placeholder. Only then are we sure
* we have a potential conflict, of the sort experienced during an
* extension upgrade.
*/
int
postgis_guc_find_option(const char *name)
{
	const char **key = &name;
	struct config_generic **res;

	/*
	 * By equating const char ** with struct config_generic *, we are assuming
	 * the name field is first in config_generic.
	 */
#if POSTGIS_PGSQL_VERSION >= 160
	res = (struct config_generic **) find_option((void *) &key, false, true, ERROR);
#else
	res = (struct config_generic **) bsearch((void *) &key,
		 (void *) get_guc_variables(),
		 GetNumConfigOptions(),
		 sizeof(struct config_generic *),
		 postgis_guc_var_compare);
#endif

	/* Found nothing? Good */
	if ( ! res ) return 0;

	/* Hm, you found something, but maybe it's just a placeholder? */
	/* We'll consider a placehold a "not found" */
	if ( (*res)->flags & GUC_CUSTOM_PLACEHOLDER )
		return 0;

	return 1;
}


/* PgSQL 12+ still lacks 3-argument version of these functions */
Datum
CallerFInfoFunctionCall3(PGFunction func, FmgrInfo *flinfo, Oid collation, Datum arg1, Datum arg2, Datum arg3)
{
    LOCAL_FCINFO(fcinfo, 3);
    Datum       result;

    InitFunctionCallInfoData(*fcinfo, flinfo, 3, collation, NULL, NULL);

    fcinfo->args[0].value = arg1;
    fcinfo->args[0].isnull = false;
    fcinfo->args[1].value = arg2;
    fcinfo->args[1].isnull = false;
    fcinfo->args[2].value = arg3;
    fcinfo->args[2].isnull = false;

    result = (*func) (fcinfo);

    /* Check for null result, since caller is clearly not expecting one */
    if (fcinfo->isnull)
        elog(ERROR, "function %p returned NULL", (void *) func);

    return result;
}
