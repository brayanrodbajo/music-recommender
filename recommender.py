# MLP for Pima Indians Dataset Serialize to JSON and HDF5
from keras.models import Sequential
from keras.layers import Dense
from keras.models import model_from_json
import numpy as np
import os
import sys
import extractfeatures
from sklearn import preprocessing
from pickle import load

def load_model(json_path, weights_path):
	# load json and create model
	json_file = open(json_path, 'r')
	loaded_model_json = json_file.read()
	json_file.close()
	loaded_model = model_from_json(loaded_model_json)
	# load weights into new model
	loaded_model.load_weights(weights_path)
	#print("Loaded model from disk")

	return loaded_model

import re
def predict_companies(mfccs, chromas, mf_ch):
	predictions = []
	regex = re.compile('model-company(.*).best.json')
	for root, dirs, files in os.walk('.'):
		for file in files:
			if regex.match(file):
				model = load_model(file, "weights"+file[5:-4]+"hdf5")
				company = str(file[13])
				if file[14:].startswith("mfcc"):
					scaler = load(open('scaler_mfcc'+company+'.pkl', 'rb'))
					mfccs_scaled = scaler.transform(mfccs)
					y = model.predict(mfccs_scaled)
				elif file[14:].startswith("ch"):
					scaler = load(open('scaler_ch'+company+'.pkl', 'rb'))
					chromas_scaled = scaler.transform(chromas)
					y = model.predict(chromas_scaled)
				else: 
					scaler = load(open('scaler'+company+'.pkl', 'rb'))
					mf_ch_scaled = scaler.transform(mf_ch)
					y = model.predict(mf_ch_scaled)		
				predictions.append(y[0][0])
	return predictions


def main(song_file_path):
	mfccs = extractfeatures.get_mfcc(song_file_path)
	chromas = extractfeatures.get_chromagram(song_file_path)
	mf_ch = np.concatenate((mfccs, chromas))
	mfccs = np.array([mfccs])
	chromas = np.array([chromas])
	mf_ch = np.array([mf_ch])

	return predict_companies(mfccs, chromas, mf_ch)



if __name__ == '__main__':
	songs_directory_path = sys.argv[1]
	output_path = sys.argv[1]
	# main(song_file_path)
	
	import csv
	with open(output_path, 'w', newline='') as myfile:
		wr = csv.writer(myfile, quoting=csv.QUOTE_ALL, delimiter=',')
		wr.writerow(["song", "C0", "C1", "C2", "C3", "C4", "C5"])
		for root, dirs, files in os.walk(songs_directory_path):
			for file in files:
				if file.endswith(".mp3"):
					try: 
						song_path = os.path.join(root, file)
						probs = [song_path]+main(song_path)
						wr.writerow(probs)
					except:
						pass
			print(root)

	

