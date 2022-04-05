#!/bin/sh
exec ruby -x "$0" "$@"
#!ruby

require 'lib_latex_utils.rb'
include Latex_Utils

renum_src_files
