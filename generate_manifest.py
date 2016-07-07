#TODO implement this in javascript????

import os
import os.path
from hashlib import md5
import json
import sys
import argparse
import shutil


def get_args():
  parser = argparse.ArgumentParser(description='generates the assets for OpenBrain')
  parser.add_argument("-b","--generatejsbundle",
                        help="Generate the asset bundle",
                        action="store_true")
  parser.add_argument("-m","--generatemanifest",
                        help="Generate a local manifest in the root",
                        action="store_true")
  parser.add_argument("--output", help="The local manifest output destination")
  parser.add_argument("-d","--deploy",
                        help="Deploy the assets to the remote",
                        action="store_true")
  parser.add_argument("--root", help="The root folder of the assets")

  return parser.parse_args()

def main():

  args = get_args()

  if(args.generatejsbundle):
    generate_bundle(args)

  if(args.generatemanifest):
    generate_manifest(args)

  if(args.deploy):
    deploy_assets(args)

def generate_bundle(args):
  os.system("react-native bundle --entry-file index.ios.js --platform ios "+
    "--dev false --bundle-output "+args.root+"/ios.index.jsbundle ")

def generate_manifest(args):
  game_dir = args.root

  assetfiles = [f for f in os.listdir(game_dir) if os.path.isfile(os.path.join(game_dir, f)) and ( ".html" in f or ".jsbundle" in f )]

  assets = []

  for assetfile in assetfiles:
    path = os.path.join(game_dir, assetfile)

    checksum = md5(open(path, 'rb').read()).hexdigest()

    name, ext = os.path.splitext(assetfile)

    asset = {'relativePath':"/"+assetfile,'checksum':checksum,'name':name,'filename':assetfile}

    assets.append(asset)

  with open(args.output, 'w') as outfile:
      json.dump(assets, outfile,
        indent=4, separators=(',', ': '))


def deploy_assets(args):
  game_dir = args.root

  assetfiles = [f for f in os.listdir(game_dir) if os.path.isfile(os.path.join(game_dir, f)) and ( '.html' in f or '.jsbundle' in f )]

  assets = []

#mkdir at deploy

  for assetfile in assetfiles:
    path = os.path.join(game_dir, f)

    checksum = md5(open(path, 'rb').read()).hexdigest()

    name, ext = os.path.splitext(assetfile)
    deploydir = "deploy"
    subdir = deploydir+"/"+assetfile+"/"+checksum

    if not os.path.exists(subdir):
      os.makedirs(subdir)

    shutil.copy(path, subdir+"/"+assetfile)

    relativepath = assetfile+"/"+checksum+"/"+assetfile
    asset = {'relativePath':relativepath,'checksum':checksum,'name':name,'filename':assetfile}
    assets.append(asset)

    manifestfile = deploydir+"/manifest.json"

    with open(manifestfile, 'w') as outfile:
      json.dump(assets, outfile, indent=4, separators=(',', ': '))

if __name__ == "__main__":
	main()
