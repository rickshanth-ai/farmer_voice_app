import pandas as pd
import joblib

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline


# ==============================
# 1. Load training dataset
# ==============================

DATASET_PATH = "dataset/training_data.csv"

data = pd.read_csv(DATASET_PATH)

print("Dataset loaded successfully!")
print("Total samples:", len(data))
print("Columns:", list(data.columns))


# ==============================
# 2. Prepare input and output
# ==============================

X = data["text"]
y = data["intent"]


# ==============================
# 3. Create AI model
# ==============================

model = Pipeline([
    (
        "tfidf",
        TfidfVectorizer(
            lowercase=True,
            ngram_range=(1, 2)
        )
    ),
    (
        "classifier",
        LogisticRegression(
            max_iter=1000
        )
    )
])


# ==============================
# 4. Train the model
# ==============================

print("\nTraining AI model...")

model.fit(X, y)

print("Training completed successfully!")


# ==============================
# 5. Save trained model
# ==============================

MODEL_PATH = "farmer_voice_model.pkl"

joblib.dump(model, MODEL_PATH)

print("\nModel saved successfully!")
print("Saved as:", MODEL_PATH)


# ==============================
# 6. Test some sample sentences
# ==============================

test_sentences = [
    "En nel payirukku poochi vandhurukku",
    "Tomato ilai yellow aagudhu",
    "Indha mannukku enna payir podalam",
    "Naalai mazhai varuma",
    "Innaiku tomato market price evlo"
]

print("\nSample Predictions:")

for sentence in test_sentences:
    prediction = model.predict([sentence])[0]
    print(f"{sentence} -> {prediction}")


print("\n================================")
print("AI TRAINING COMPLETED!")
print("================================")