AFNetworking handles network requests using tasks instead of operations. These tasks are not added to any sort of queue and as such, many tasks can execute concurrently. 
OCHTTPRequestOperationManager is a wrapper class that executes a set of tasks serially.
