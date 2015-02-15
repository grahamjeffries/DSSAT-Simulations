#!/bin/sh

ifort -fixed -c ModuleDefs.f90
ifort -fixed -c OPHEAD.f90
ifort -fixed -c SoilMixing.f90
ifort -fixed -c SLigCeres.f90
ifort -fixed -c OPSUM.f90
ifort -fixed -c SC_CNG_mods.f90
