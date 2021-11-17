import numpy as np
import os
import json
import unicodedata
import codecs
import csv
import tqdm
import unicodedata
import re
from string import printable
import pandas as pd
import re
from functools import partial
# from pip._vendor.webencodings import Encoding
from greeklish.converter import Converter


from greeklish.converter import Converter
from pyparsing import Regex

myconverter = Converter(max_expansions=1)
s = str(myconverter.convert('μια φορά και έναν καιρό.'))
s = re.sub(r"([.!?])", r" \1", s)

