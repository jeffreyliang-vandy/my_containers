FROM lukasblecher/pix2tex as latex-ocr

FROM breezedeus/cnocr as base

COPY --from=latex-ocr /latexocr /latexocr

RUN pip install --no-cache-dir cnstd

RUN git clone https://github.com/breezedeus/Pix2Text.git

RUN pip install --no-cache-dir pix2text pyperclip streamlit

COPY ./api ./api

FROM base as test
RUN python ./api/run.py


FROM base as app
EXPOSE 8501
CMD python ./api/run.py

