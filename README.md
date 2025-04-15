# Rails Base API

This is a base Rails API application configured to run with Docker and Docker Compose.

## Prerequisites

*   Docker: [Install Docker](https://docs.docker.com/get-docker/)
*   Docker Compose: Usually included with Docker Desktop. [Install Docker Compose](https://docs.docker.com/compose/install/) if needed.

## Setup

1.  **Clone the repository (if you haven't already):**
    ```bash
    git clone git@github.com:erick-tmr/rails-base-api.git
    cd rails-base-api
    ```

2.  **Build the Docker images:**
    This command builds the `web` service image based on the `Dockerfile` and pulls the `postgres` image.
    ```bash
    docker compose build
    ```

3.  **Set up the database:**
    This command runs the database setup task within a temporary container for the `web` service.
    ```bash
    docker compose run --rm web bundle exec rails db:prepare
    ```
    *Note: `db:prepare` will create the database if it doesn't exist, load the schema, and run any pending migrations. If you only need to run migrations, use `docker compose run --rm web bundle exec rails db:migrate`.*

## Running the Application

1.  **Start the services:**
    This command starts the `db` and `web` services in the background.
    ```bash
    docker compose up -d
    ```

2.  **Access the API:**
    The Rails application should now be running and accessible at `http://localhost:3000`.

## Development & Debugging

### Running Tests

Execute the test suite using:
```bash
docker compose run --rm web bundle exec rails test
```

### Using `pry` for Debugging

The `pry-byebug` gem is included for interactive debugging.

1.  **Ensure the application is running:**
    ```bash
    docker compose up -d
    ```

2.  **Attach to the running `web` container:**
    ```bash
    docker compose attach web
    ```

3.  **Trigger `binding.pry`:** Add `binding.pry` in your Rails code where you want to pause execution. When the code hits that line, the application will pause, and you'll get a `pry` prompt in the terminal where you attached.

4.  **Detach:** To detach from the container without stopping it, press `Ctrl+P` then `Ctrl+Q`.

### Running Rails Commands

You can run any Rails command (like generators, console, etc.) using `docker compose run --rm web bundle exec`:

*   **Rails Console:**
    ```bash
    docker compose run --rm web bundle exec rails c
    ```
*   **Generate a scaffold:**
    ```bash
    docker compose run --rm web bundle exec rails g scaffold Post title:string body:text
    ```
    *(Remember to run migrations after generating models/scaffolds: `docker compose run --rm web bundle exec rails db:migrate`)*

## Stopping the Application

To stop the running services and remove the containers:
```bash
docker compose down
```

To stop the services without removing the containers (useful for quick restarts):
```bash
docker compose stop
```

## Configuration

*   **Database:** Configuration is in `config/database.yml` and uses the `DATABASE_URL` environment variable set in `docker-compose.yml`.
*   **Docker:** Service definitions are in `docker-compose.yml`. The Rails application image build process is defined in `Dockerfile`.
*   **Environment Variables:** Development environment variables are primarily set in `docker-compose.yml`.
