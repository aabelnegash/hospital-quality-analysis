import pandas as pd

hospital_data = pd.read_csv("data/input/hospital_clean.csv")

sample_data = hospital_data.head(200)

sample_data.to_csv("data/sample/hospital_clean_sample.csv", index=False)