from fastapi import FastAPI
import joblib

app = FastAPI()

model = joblib.load("farmer_voice_model.pkl")


@app.get("/")
def home():
    return {"message": "Farmer Voice AI API is running!"}


@app.get("/predict")
def predict(text: str):
    prediction = model.predict([text])[0]

    return {
        "text": text,
        "intent": prediction
    }