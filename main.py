import numpy as np
import os
import json
import unicodedata
import codecs
import csv
import tqdm
import unicodedata
import re
from functools import partial
from string import printable
import pandas as pd
from greeklish.converter import Converter


myconverter = Converter(max_expansions=1)


fix_mojibake_escapes = partial(
     re.compile(rb'\\u00([\da-f]{2})').sub,
     lambda m: bytes.fromhex(m.group(1).decode()))

def remove_emoji(df):
  return df.applymap(lambda y: ''.join(filter(lambda x: x in printable, y)))

final_df = pd.DataFrame()

dir = "inbox"
folders = os.listdir(dir)
path_list = []
paths_senders = {}
for folder in folders:
    for file in os.listdir(os.path.join("inbox",folder)):
        if file.startswith("message"):
            path = os.path.join(dir,folder,file)
            try:
                with open(path, 'rb') as file:
                    repaired = fix_mojibake_escapes(file.read())
                    data = json.loads(repaired.decode('utf8'))

                    sender_name = data["participants"][0]["name"]
                    messages = data["messages"]
                    new_conversation = []
                    for k in messages:
                        if "content" in k.keys():
                            new_conversation.append(k)
                    pairs = []
                    message = [] #message pair


                    for m in new_conversation[::-1]:
                        if len(message) == 0 or len(message) == 2:
                            if m["sender_name"] != "Antonis Parlapanis":
                                message = []
                                message.append(m["content"])
                        elif len(message) == 1:
                            if m["sender_name"] != "Antonis Parlapanis":
                                message[0] = message[0]+ " " + m["content"] #enwnei duo munhmata sth seira
                            else:
                                message.append(m["content"])
                        else:
                            if m["sender_name"] == "Antonis Parlapanis":
                                message[1] = message[1] + " " + m["content"]
                        pairs.append(message)
                    new_pair = []
                    for pair in pairs:
                        if len(pair) == 2:
                            new_pair.append(pair)


                    me = []
                    sender = []

                    for pair in new_pair:
                        sender.append(pair[0])
                        me.append(pair[1])

                    conv_df = pd.DataFrame()
                    conv_df["sender"] = np.array(sender)
                    conv_df["me"] = np.array(me)
                    conv_df = conv_df.drop_duplicates(keep="first")

                    # conv_df = remove_emoji(conv_df)
                    final_df = pd.concat([conv_df,final_df],axis=0)




            except json.decoder.JSONDecodeError:
                print("There was a problem accessing the equipment data.")




final_df.drop(final_df[final_df["sender"]=="  "].index,inplace=True)
final_df.drop(final_df[final_df["me"]=="  "].index,inplace=True)


#
final_df["sender"] = final_df["sender"].apply(lambda x: myconverter.convert(x))
final_df["me"] = final_df["me"].apply(lambda x: myconverter.convert(x))




# Lowercase, trim, and remove non-letter characters
def normalize(s):
    s = s.lower().strip()
    s = re.sub(r"([.!?])", r" \1", s)
    s = re.sub(r"[^a-zA-Z.!?]+", r" ", s)
    return s

final_df["sender"] = final_df["sender"].apply(lambda x: normalize(x[0]))
final_df["me"] = final_df["me"].apply(lambda x: normalize(x[0]))

print(final_df.head(200))


final_df.to_csv('out.csv', sep='\t', encoding='utf-8')




