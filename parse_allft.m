function flights_data = parse_allft(file_path)

% Initialize cell arrays to store column data
departure_airport = {};
arrival_airport = {};
flight_number = {};
airline_code = {};
aircraft_type = {};
scheduled_departure = {};
scheduled_arrival = {};

% Open the file
fid = fopen(file_path, 'r');
if fid == -1
    error('Failed to open file: %s', file_path);
end

% Skip the first line
fgetl(fid);

% Read the file line by line
lineIndex = 1; % Keep track of the number of lines read
while ~feof(fid)

    % Parse line from the ALLFT+ file
    line = fgetl(fid);
    % Use textscan instead of strsplit to correctly handle empty columns
    flight_details = textscan(line, '%s', 'Delimiter', ';', 'CollectOutput', true);
    flight_details = flight_details{1}; % Extract the cell array

    % Append data to cell arrays
    departure_airport{lineIndex} = flight_details{1};
    arrival_airport{lineIndex} = flight_details{2};
    flight_number{lineIndex} = flight_details{3};
    airline_code{lineIndex} = flight_details{4};
    aircraft_type{lineIndex} = flight_details{5};

    % Parse waypoints from the 86th column
    waypoints = strsplit(flight_details{86}, ' ');

    % Extract scheduled departure and arrival from waypoints
    % ETD is given by the first waypoint
    etd_parts = strsplit(waypoints{1}, ':');
    scheduled_departure{lineIndex} = etd_parts{1};
    % ETA is given by the last waypoint
    eta_parts = strsplit(waypoints{end}, ':');
    scheduled_arrival{lineIndex} = eta_parts{1};

    % Increment line count
    lineIndex = lineIndex + 1;
end

% Close the file
fclose(fid);

% Convert cell arrays to a table
flights_data = table( ...
    departure_airport', arrival_airport', flight_number', ...
    airline_code', aircraft_type', scheduled_departure', ...
    scheduled_arrival', ...
    'VariableNames', {'departure_airport', 'arrival_airport', ...
    'flight_number', 'airline_code', 'aircraft_type', ...
    'scheduled_departure', 'scheduled_arrival'});
end

