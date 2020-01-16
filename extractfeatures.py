import numpy as np
import librosa

def get_mfcc(file_path):
    song, sr = librosa.load(file_path)
    mfccs = librosa.feature.mfcc(song, sr=sr,n_mfcc=13)
    mfcc_average = np.mean(mfccs, axis=1)
    return mfcc_average

def get_chromagram(file_path):
    song, sr = librosa.load(file_path)
    chromagram = librosa.feature.chroma_stft(song, sr=sr)
    chroma_average = np.mean(chromagram, axis=1)
    return chroma_average
