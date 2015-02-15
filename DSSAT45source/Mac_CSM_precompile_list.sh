#!/bin/sh

gfortran -ffixed-form -c ModuleDefs.f90
gfortran -ffixed-form -c OPHEAD.f90
gfortran -ffixed-form -c SoilMixing.f90
gfortran -ffixed-form -c SLigCeres.f90
gfortran -ffixed-form -c OPSUM.f90
gfortran -ffixed-form -c SC_CNG_mods.f90