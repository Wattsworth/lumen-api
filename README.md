# Lumen API

This is part of the Wattsworth Sensor Network framework. 
See `http://wattsworth.net` for details. This code is designed
to support the Lumen Client available at `https://github.com/wattsworth/lumen-client`

## Development Server
To run a local version of the API server do the following:

1. Install the project gems:

    $> bundle install
    
2. Create a development database and a default user

    $> rails db:migrate
    $> rake local:bootstrap
       
3. Start the development server
    
    $> rails s

## Testing
Tests are provided with rspec. To execute test suite:

1. Install the project gems

    $> bundle install

2. Create a test database
   
    $> RAILS_ENV=test rails db:migrate
    
3. Run rspec binstub

    $> bin/rspec
    
