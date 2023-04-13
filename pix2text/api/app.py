# Adapted from https://github.com/kingyiusuen/image-to-latex/blob/main/api/app.py

from http import HTTPStatus
from fastapi import FastAPI, File, UploadFile, Form
from PIL import Image
from io import BytesIO
from pix2tex.cli import LatexOCR
from pix2text import Pix2Text

model = None
app = FastAPI(title='pix2tex API')


def read_imagefile(file) -> Image.Image:
    image = Image.open(BytesIO(file))
    return image


@app.on_event('startup')
async def load_model():
    global model
    if model is None:
        model = Pix2Text(analyzer_config=dict(model_name="mfd"))


@app.get('/')
def root():
    '''Health check.'''
    response = {
        'message': HTTPStatus.OK.phrase,
        'status-code': HTTPStatus.OK,
        'data': {},
    }
    return response


@app.post('/predict/')
async def predict(file: UploadFile = File(...)) -> str:
    """Predict the Latex code from an image file.

    Args:
        file (UploadFile, optional): Image to predict. Defaults to File(...).

    Returns:
        str: Latex prediction
    """
    global model
    image = file.file
    outs = model.recognize(image)
    result = '\n'.join([out['text'] for out in outs])
    return result
