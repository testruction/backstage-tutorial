FROM docker.io/spotify/techdocs:v1.2.3
RUN mkdir /output \
    && pip install --no-cache --force-reinstall \
      'mkdocs-techdocs-core~=1.3.2' \
    && pip install --no-cache --force-reinstall \
      'mkdocs-material~=9.5.3' \
      'mkdocs-mermaid-plugin~=0.1.1' \
      'mkdocs-monorepo-plugin~=1.1.0' \
      'mkdocs-diagrams~=1.0.0' \
      'mkdocs-glightbox~=0.3.6'