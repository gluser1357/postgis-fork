/**********************************************************************
 *
 * PostGIS - Spatial Types for PostgreSQL
 * http://postgis.net
 *
 * PostGIS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * PostGIS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with PostGIS.  If not, see <http://www.gnu.org/licenses/>.
 *
 **********************************************************************
 *
 * Copyright (C) 2024 Sam Peters <gluser1357@gmx.de>
 *
 **********************************************************************/

#include "liblwgeom.h"
#include "liblwgeom_internal.h"

int encodeToBits(double value, double min, double max);
int encodeToBitsStraight(double xa, double ya, double xb, double yb, double xmin, double ymin, double xmax, double ymax, int straightPosition);
void removePoints(POINTARRAY *points, GBOX *bounds, bool closed, bool cartesian_hint);
