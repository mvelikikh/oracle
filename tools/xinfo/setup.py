#!/usr/bin/env python

'''
Setuptools installer for xinfo.
'''

import pathlib
import re

import setuptools

setuptools.setup(
  long_description=pathlib.Path('README.rst').read_text(encoding='utf8')
)