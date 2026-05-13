import pandas as pd

hospital_data = pd.read_csv("data/input/hospital_clean.csv")

sample_data = hospital_data.sample(n=200, random_state=1)

sample_data.to_csv("data/sample/hospital_clean_sample.csv", index=False)