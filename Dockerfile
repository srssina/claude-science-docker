FROM ubuntu:24.04

RUN apt update && apt install -y curl bubblewrap socat ca-certificates

RUN curl -fsSL -o /usr/local/bin/claude-science \
    https://downloads.claude.ai/claude-science/latest/linux-x64 \
    && chmod +x /usr/local/bin/claude-science

EXPOSE 8765
CMD ["claude-science", "serve", "--port", "8765", "--host", "0.0.0.0", "--no-browser"]
