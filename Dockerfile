FROM python:3.11-slim-bookworm


COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["/collect/main.py"]
ENTRYPOINT ["python"]