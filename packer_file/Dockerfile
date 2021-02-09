FROM python:3.8
WORKDIR /app

COPY my-app/requirements.txt /app/
COPY my-app/my_app.py /app/
RUN mkdir app
COPY my-app/app/ /app/app

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

RUN export FLASK_ENV=my_app.py
CMD ["flask", "run", "--host=0.0.0.0"]
