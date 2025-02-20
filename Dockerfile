FROM public.ecr.aws/lambda/python:3.12

# Write Docker commands to package your Python application with its dependencies
# so that it can

# tips: a python 'requirements.txt' file to insall the Python dependencies with pip
# can be generated using 'poetry export --without-hashes > lambda_app/requirements.txt'
# before building the image with 'docker build ...'

WORKDIR /var/task

# Copier les fichiers de l'application
COPY lambda_app/ lambda_app/ 

# Copier les fichiers restants (comme event.json si nécessaire)
COPY events/ events/

COPY pyproject.toml poetry.lock ./

# Copier et rendre exécutable le script RIE
COPY lambda-entrypoint.sh /lambda-entrypoint.sh


# Installer Poetry
RUN pip install --upgrade pip && \
    pip install poetry && \
    poetry self add poetry-plugin-export 

# Exporter les dépendances depuis Poetry en requirements.txt
RUN poetry export --without-hashes -o lambda_app/requirements.txt

# Installer les dépendances avec pip
RUN pip install --no-cache-dir -r lambda_app/requirements.txt

RUN chmod +x /lambda-entrypoint.sh

# Installer l'émulateur d'environnement d'exécution Lambda (RIE)
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/local/bin/aws-lambda-rie
RUN chmod +x /usr/local/bin/aws-lambda-rie

# Set CMD so that the entry point of the lambda is the 'lambda_handler' function.
# Définir l'entrypoint de la fonction Lambda
#  Définir l'entry AWS Lambda avec _HANDLER
EXPOSE 8080
ENV _HANDLER=lambda_app.app.lambda_handler

ENTRYPOINT [ "/usr/local/bin/aws-lambda-rie", "/lambda-entrypoint.sh" ]


