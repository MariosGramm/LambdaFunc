import json

tasks = []

def addTask(event,context) :
    body = json.loads(event['body'])
    task = body.get("task"," ")
    if not task :
        return{
            "statusCode":"400",
            "body":json.dumps({
                "message":"Task cannot be empty.Please enter a valid task."
            })
        }
    tasks.append(task)
    return{
        "statusCode":"200",
        "body":json.dumps({
            "message":f"Task {task} has been added to the list.",
            "tasks":tasks
        })
    }

def deleteTask(event,context) :
    body = json.loads(event['body'])
    task = body.get("task"," ")
    if not task :
        return{
            "statusCode":"400",
            "body":json.dumps({
                "message":"Task cannot be empty.Please enter a valid task."
            })
        }
    tasks.remove(task)
    return{
        "statusCode":"200",
        "body":json.dumps({
            "message":f"Task {task} has been deleted from the list.",
            "tasks":tasks
        })
    }

def listTasks(event,context):
    return{
        "statusCode":"200",
        "body":json.dumps({
            "tasks":tasks
        })
    }

def showMenu(event,context):
    menu = """
    Please select one of the options below:
    --------------------------------------
    1. Add task
    2. Delete task
    3. List all tasks
    4. Quit
    --------------------------------------
    """
    return{
        "statusCode":"200",
        "body":json.dumps({
            "message": menu
        })
    }

def showHelp(event, context):
    help_text = """
    Welcome to the To-do list API!
    -----------------------------------
    Here are the available endpoints:

    1. GET /help
       - Provides information about how to use the API.
    
    2. GET /
       - Displays the main menu with options to add, delete, or list tasks.

    3. POST /task
       - Adds a new task. You need to send a JSON body with the task field.
       Example:
         {"task": "Your task description"}

    4. DELETE /task
       - Deletes an existing task. You need to send a JSON body with the task field.
       Example:
         {"task": "Your task description"}

    5. GET /tasks
       - Lists all the tasks currently in the list.
    
    6. 4. Quit
       - Exits the application.
    """
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": help_text
        })
    }

def lambda_handler(event,context):
    path = event['resource']

    if path == '/' and event['httpMethod'] == 'GET' :
       return showMenu(event,context) 
    elif path == '/add' and event['httpMethod'] == 'POST' :
        return addTask(event,context)
    elif path == '/delete' and event['httpMethod'] == 'DELETE' :
        return deleteTask(event,context)
    elif path == '/tasks' and event['httpMethod'] == 'GET' :
        return listTasks(event,context)
    elif path == '/help' and event['httpMethod'] == 'GET' :
        return showHelp(event,context)
    else :
        return{
            "statusCode":"404",
            "body":json.dumps({
                "message":"Resource not found."
            })
        }
    
    