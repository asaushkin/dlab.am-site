FROM public.ecr.aws/lambda/python:3.9

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}" \
    && rm requirements.txt

COPY . ${LAMBDA_TASK_ROOT}/
