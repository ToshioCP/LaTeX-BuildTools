#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

require_relative 'lib_latex_utils.rb'
include LatexUtils

renum_src_files
