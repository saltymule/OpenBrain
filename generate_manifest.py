#TODO implement this in javascript????

from os import listdir
from os.path import isfile, join, splitext
from hashlib import md5
import json

def main():

  game_dir = './web/games'

  htmlfiles = [f for f in listdir(game_dir) if isfile(join(game_dir, f)) and '.html' in f]

  assets = []

  for htmlfile in htmlfiles:
    path = join(game_dir, f)

    checksum = md5(open(path, 'rb').read()).hexdigest()

    name, ext = splitext(htmlfile)

    asset = {'relativePath':"/"+htmlfile,'checksum':checksum,'name':name,'filename':htmlfile}

    assets.append(asset)


  print json.dumps(assets,
        indent=4, separators=(',', ': '))


if __name__ == "__main__":
	main()
