FROM lnbits/lnbits:latest

# 1. Switch to root to perform surgery
USER root

# 2. Install Git (Required for extensions)
RUN apt-get update && apt-get install -y git && apt-get clean

# 3. THE FIX: Install 'uv' globally into /usr/local/bin
# This ensures User 1000 can actually run it!
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# 4. Download the User Manager extension
RUN git clone https://github.com/lnbits/usermanager /app/lnbits/extensions/usermanager

# 5. CRITICAL SECURITY: Give the ENTIRE app folder to User 1000.
# This includes the database, the code, and the virtual environment.
RUN chown -R 1000:1000 /app

# 5a. Ensure the data directory exists and is owned by user 1000
RUN mkdir -p /app/data && chown -R 1000:1000 /app/data

# 6. Create the user 1000 (if it doesn't exist) to prevent "User not found" errors
RUN useradd -u 1000 -m lnbits || true

# 7. NOW we switch to the safe user.
# This container will run as a restricted user, unable to touch system files.
USER 1000

# 8. Set the extension to auto-install
ENV LNBITS_EXTENSIONS_DEFAULT_INSTALL="usermanager"