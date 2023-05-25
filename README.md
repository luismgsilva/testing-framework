# Build System Framework User-Manual

This user manual is designed for individuals who are familiar with the UNIX command-line interface but have no prior experience with the Build System Framework (BSF).

## Prerequisites

### Ruby Instalation

Before using BSF, you need to install Ruby. If you're using Debian or Ubuntu, you can install Ruby and its essential components by running the following command:

```sh
    sudo apt-get install ruby-full build-essential
```


#### Dependecies
BSF relies on several Ruby gems to function properly. To install the required gem dependencies, execute the following command:

```sh
$ gem install erb json sinatra terminal-table
```

Alternatively, you can use a Gemfile within the framework to install the dependencies by following these steps:

1. Install Bundler
```sh
$ sudo gem install bundler
```
2. Run bundle install:
```sh
$ bundle install
```


Visit for more information:

    https://www.ruby-lang.org/en/documentation/installation/#apt


<!-- ### RUBYLIB Environment Variable

To correctly execute the framework it is necessary to define the RUBYLIB environment variable to the framework lib folder.

Execute the following command and replace `<bsf-path>` to the framework path folder you stored it.

    $ export RUBYLIB=<bsf-path>/lib:$RUBYLIB -->


## Introduction
BSF is a versatile framework designed to automate task execution and facilitate result comparison between different iterations. It operates using a command-line interface, similar to Git, where each command is executed as an independent process with its own scope and variable access.

By executing commands in separate processes, BSF ensures encapsulation and isolation of tasks, preventing unintended interactions and allowing for parallel execution when applicable. Each command within BSF can access and manipulate the variables specific to its execution, providing a controlled and organized environment.

The independent command execution approach in BSF offers flexibility and scalability, enabling users to perform various operations and automate complex tasks while maintaining modularity and reliability. It allows for seamless integration with existing workflows and systems, making BSF a powerful tool for task automation and result comparison.



## Configuration File
The config.json file is an essential component of BSF, and it contains the necessary parameters and configurations for the framework to function properly. It follows a JSON format and consists of two main sections: "sources" and "tasks".


### Sources
The "sources" section defines the sources (repositories) that BSF can clone and work with. Each source is represented as an object with a unique name and the following properties:

- "repo": Specifies the URL of the repository to clone.
- "branch" (optional): Specifies the branch of the repository to clone. If not provided, the default branch will be used.

Here's an example of the "sources" section in the config.json file:

```json
"sources": {
    "source1": {
        "repo": "https://github.com/user/repo1",
        "branch": "main"
    },
    "source2": {
        "repo": "https://github.com/user/repo2"
    }
}
```

In this example, there are two sources defined: "source1" and "source2". Each source is represented as an object with a unique name. Within each source object, you specify the repository URL using the "repo" property. Additionally, you can specify the branch of the repository using the "branch" property. If the "branch" property is not provided, the default branch of the repository will be used.

It's important to note that once the sources are defined in the config.json file, they cannot be modified. If you need to change a source or add a new one, you will need to update the config.json file accordingly.

### Tasks
A task in the Build System Framework (BSF) represents a specific operation to be executed. Each task consists of parameters that need to be fulfilled for the task to be successfully completed. Except for the description parameter, which accepts a single string, each parameter accepts a bash command as input, either a single string or an array of strings. This design allows for flexibility in executing various types of scripts using bash command invocations, as the core execution, such as tests, is not dependent on Ruby. These scripts should be located in the config folder upon BSF initialization.

Here's an example of the "tasks" section in the config.json file:
```json
"tasks": {
    "task1": {
        "description": "Task 1 description",
        "pre_condition": "precondition command",
        "execute": "execution command",
        "publish_header": "commit message header",
        "comparator": "comparison command",
        "report": "report command"
    },
    "task2": {
        "description": "Task 2 description",
        "pre_condition": "precondition command",
        "execute": "execution command",
        "publish_header": "commit message header",
        "comparator": "comparison command"
    }
}

```

These examples demonstrate the structure of the config.json file, including the required parameters for sources and tasks. Feel free to customize the names, descriptions, and commands according to your specific requirements.

### Description Parameter
The description parameter provides a detailed description of the task's purpose. When executing the `$ bsf tasks` command to view a list of all tasks in the system, the value of this parameter will be displayed.

### Pre-Conditions Parameter
The pre_condition parameter performs various validations when executing the $ bsf execute command for the current task. If the dependencies are confirmed, the execution proceeds; otherwise, the failure is reported. It accepts either a single string or an array of strings as input.

### Execute Parameter
The execute parameter defines the main objective of the task. It contains the steps and procedures to be executed, such as the steps for HS Dejagnu bare metal testing. The execution occurs within a unique workspace folder. The execute parameter uses bash as the scripting language and accepts a single string or an array of strings as input. This means that the task's execution is independent of Ruby and can invoke separate scripts if necessary.

### Publish Header Parameter
The publish_header parameter sets the commit message that will be stored in the git commit when using the bsf publish command. It accepts input in JSON format and can accept multiple JSON formats. BSF concatenates all JSON into a unified format.

### Comparator Parameter
The comparator parameter handles the comparison operation between previous execution iterations. It uses an internal variable ($var(@OPTIONS)) defined by BSF, which follows a specific syntax based on the input provided in the bsf comparator command execution. More information about this syntax can be found in the REFERENCE section.

### Report Parameter
The report parameter executes a bash command for generating the task's report. Similar to the comparator parameter, it uses an internal variable ($var(@OPTIONS)) defined by BSF, which follows a specific syntax based on the input provided in the bsf report command execution. More information about this syntax can be found in the REFERENCE section.


## Framework Initialization


To initialize the Build System Framework (BSF), you need to have a folder that contains a mandatory config.json file, which was introduced earlier, defining the framework's configuration and execution. Additionally, any other dependencies required by the framework, such as scripts invoked from the config.json file, should be present in the folder.

The folder can also include other types of dependencies, such as scripts called within the config.json file.

A prebuilt configuration for BSF can be found in the following link:

```sh
https://github.com/luismgsilva/tbsf_config
```

Alternatively, you can clone a BSF Environment. This approach facilitates sharing test results among developers and allows you to reproduce a developer's work in the same environment in which it was originally conducted. To clone a BSF Environment, use the following command:

```sh
    $ bsf clone <gitrepo> <dir>
```

For example:
```sh
$ bsf clone https://github.com/<user>/<repo> /home/user/BSF
```

This command clones the BSF Environment from the specified Git repository to the given directory.


## Variables

BSF supports two types of variables within the config.json file: Input Variables and Internal Variables. These variables provide a way to modify executions without directly altering the config.json file.

`Input Variables` are defined after BSF has been initialized and allow for dynamic customization. They are denoted by the following syntax:

```sh
    $var(VAR)
``` 
You can define input variables according to your specific needs.

`Internal Variables` are defined internally by the BSF framework. They serve specific purposes within the framework and are denoted by the following syntax:

```sh
    $var(@VAR)
```
Internal variables are predefined and used by BSF for various operations and configurations.

BSF uses the following internal variables within the config.json file:

- $var(@ROOT): Path to the framework environment.
- $var(@SOURCE): Path to all the repositories.
- $var(@WORKSPACE): Path to all the tasks' execution files.
- $var(@CONFIG_SOURCE_PATH): Path to the internal config folder used in the initialization.


These variables provide flexibility and control over the execution of tasks within BSF.

To list all input variables defined in the config.json file, use the command:
```sh
$ bsf vars
```

To define input variables, use the following command format:
```sh
$ bsf set <var>=<value>
```

For example, to initialize an input variable named PREFIX with the value /home/user/install, use:
```sh
$ bsf set PREFIX=/home/user/install
```

Feel free to customize the variable names and values according to your specific needs.
# Commands

## Start a working BSF Environment
BSF is initialized with a folder containing a mandatory config.json file, the one previously mentioned. Other dependencies, such as a script that is invoked from the `config.json` file, must also be present in the folder.

The example that follows illustrates a potential folder's contents for BSF's initialization.
```
folder
├── config.json
├── scripts
│   ├──compare.rb
│   └── report.rb
├── site-exp
│   └── report.rblinux-qemu.siteexp.erb
```

To initialize BSF by specifying the folder containing the `config.json`, execute the following command.
    
```sh
$ bit init <folderpath>


$ bsf init /home/user/folder        # Initializes 

Another approach is to clone a BSF environment. This helps to share test results among developers, as well as reproduce a developer\'s work in the same environment on which it was originally conducted. To so do, execute the following command.
```sh
$ bsf clone <gitrepo> <dir>


$ bsf clone https://github.com/user/repo /home/user/BSF     # Clones BSF Environment from Git Repository to the given path
```

<!-- | Example                                                       | Definition                                                       |
|---------------------------------------------------------------|------------------------------------------------------------------|
| *$ bsf clone `https://github.com/user/repo` `/home/user/BSF`* | Clones BSF Environment from Git Repository to the given path     |
 -->


## Work with Sources

BSF provides several commands to work with sources defined in the config.json file.

### Clone a Source
To clone a source that is defined in the config.json file, use the following command:
```sh
$ bsf sources get {name} 
```
You can specify the name of the source to clone. For example:
- `$ bsf sources get gcc` clones the gcc source into the BSF environment.
- `$ bsf sources get gcc toolchain` clones both gcc and toolchain sources into the BSF environment.

If no name is provided, the command will clone all sources defined in the config.json file.

-----
### Delete a Source
To delete a source after it has been cloned, use the following command:
```sh
$ bsf sources delete <name>
```
This command will remove the specified source's folder within the sources folder in the BSF environment. For example:

- `$ bsf sources delete gcc` deletes the gcc source from the BSF environment.

-----
### List all Sources in config.json
To list all the sources defined in the config.json file, use the following command:
```sh
$ bsf sources list 
```
This command will display a list of all the sources defined in the configuration file.
----
### Show all cloned Sources
To show all the cloned sources in the BSF environment, use the following command:
```sh
$ bsf sources show
```
This command will display a list of all the cloned sources within the BSF environment.



## Work with Input Variables
BSF provides commands to define and list input variables within the config.json file.
### Define Input Variable 
To define an input variable, use the following command, specifying the variable name and its corresponding value:
```sh
$ bsf set <var>=<value>
``` 
For example, to define an input variable named PREFIX with the value /home/user/install, use the command:
```sh
$ bsf set PREFIX=/home/user/install
```
You can customize the variable name and value according to your needs.

### List all Input Variables

To list all input variables defined in the config.json file, use the following command:
```sh
$ bsf vars
```
This command will display a list of all input variables defined within the config.json file.

## Work with tasks
BSF provides several commands to work with tasks defined in the config.json file.
### Execute a task
To start the execution of a task, use the following command:
```sh
    $ bsf execute {task}
``` 

You can specify the name of the task to execute. For example:

- `$ bsf execute hs-gcc-baremetal` executes the hs-gcc-baremetal task.
- `$ bsf execute hs-gcc-baremetal hs-gcc-linux` executes both the hs-gcc-baremetal and hs-gcc-linux tasks.

If no task is specified, the command will execute all tasks defined in the config.json file.
------

### Check a log of a task

The log command allows you to view the log file of a specific task. By default, it displays the contents of the log file. You can also use the -f flag to follow the log file in real-time.

```sh
$ bsf log [-f] <task>
```

For example:
- `$ bsf log hs-gcc-baremetal` prints the log file of the hs-gcc-baremetal task.
- `$ bsf log -f hs-gcc-baremetal` follows the log file of the hs-gcc-baremetal task.
----

### Check tasks' status
To check the status of each task, including whether the execution was successful or failed, use the following command:

```sh
    $ bsf status
```
This command displays the status of each task defined in the config.json file.

-----
## Internal Git 
### Git Commands
In order to access the internal git repository inside the framework you can acomplish that by executing the following command. 

The `${gitcommands}` represents native git commands that will be executed within the framework git environment.
```sh
    $ bsf git ${gitcommands}


    $ bsf git init                  # Initializes a Git Repository inside the BSF Environment
    $ bsf git log                   # Prints the log of the BSF Git Repository
```
-----
### Publish results
To publish each execution iteration of a single or multiple tests, execute the following command.

*You must initilize a internal git repository if first time* 
```sh
    $ bsf publish
```
---
### Search Commit Messages
To search on each commit message of the internal git repository execute the following command by passing the key and value you wish to match to.
```sh
    $ bsf search $<var>=<value>


    $ bsf search build_date=20221011                    # Returns commit where the arguments are matched
    $ bsf search build_date=20221011 hash=484f32        # Returns commit where both arguments are matched 
```

----

### List persistent folder
To list all the files and folders within the persistent workspace execute the following command

```sh
    $ ls <task> {commit_id}


    $ bsf ls hs-gcc-baremetal               # Returns list of files within hs-gcc-baremetal's persistent_ws, locally
    $ bsf ls hs-gcc-baremetal HEAD          # Returns list of files within hs-gcc-baremetal's persistent_ws of HEAD commit id
```

----

### Print a file's content
To print a file's content within the persistent workspace, execute the following command
```sh
    $ cat <task> <file> {commit_id}

    $ bsf cat hs-gcc-baremetal gcc.sum          # Returns gcc.sum file within hs-gcc-baremetal persistent_ws, locally
    $ bsf cat hs-gcc-baremetal gcc.sum HEAD     # Returns gcc.sum file within hs-gcc-baremetal persistent_ws of HEAD commit id
```
<!-- | Example                                       | Definition                                                   |
|-----------------------------------------------|--------------------------------------------------------------|
| *$ bsf cat hs-gcc-baremetal gcc.sum HEAD*     | Returns gcc.sum file within hs-gcc-baremetal's persistent_ws of HEAD commit id              |
| *$ bsf cat hs-gcc-baremetal gcc.sum*          | Returns gcc.sum file within hs-gcc-baremetal persistent_ws locally                | -->

<!-- Note: The `commit_id` is not mandatory, if missing, the local file will be displayed. -->






-------------------------
-------------------------
-------------------------
-------------------------
-------------------------











## Capability to store past executions data for future comparisons.

### Publish current results

In order to compare past executions data it is necessary to store them. In order to do so execute the following command.

This command will execute a `git commit -am <commit_msg>` internally and pass as commit_msg all the JSON format files containing everything about the the tasks' execution. This implies tool versions, build date, etc

    $ bsf publish

### Comparasion

In order to make a comparasion between past execution iterations it is mandatory to have them stored in the framework internal git repository. After publishing the results using the previous command, we must extract the commit ids of the tests we wish to compare. We can achive this by executing the internal git log

    $ bsf git log


<!-- 
To create a comparasion between two hashs (or tasgs) execute the following command by replacing the \<hash1\> and \<hash2\> by the corresponding commit ids you wish to compare -->

To compare past executions data execute the following command.

    $ bsf compare <task> <hash1>:<hash2> ${args}
    $ bsf compare all <hash1>:<hash2> ${args}


| Example                                            | Definition                                                   |
|----------------------------------------------------|--------------------------------------------------------------|
| *$ bsf compare all 2019.09:2021.03*                | Returns all tasks' comparasion details  between 2019.09 vs 2021.03 |
| *$ bsf compare hs-gcc-baremetal 2019.09:2021.03*   | Returns hs-gcc-baremetal task comparasion details between 2019.09 vs 2021.03 |

<!-- | *$ bsf cat hs-gcc-baremetal gcc.sum*          | Returns gcc.sum file within hs-gcc-baremetal persistent_ws locally                | -->

<!-- 
Note that you can execute an agregator to all comparasion if your `config.json` has that implementation. To do so execute the following command. -->

<!-- $ bsf compare all <hash1>:<hash2> ${args} -->

<!-- | Example                                            | Definition                                                   | -->
<!-- |----------------------------------------------------|--------------------------------------------------------------| -->
<!-- | *$ bsf compare all 2019.09:2021.03*   |                                                              | -->
<!--  -->
Note: The `${args}` are arguments passed directly to the script responsable for the comparasion.

# Script capabilities
<!-- Some of the arguments you can pass to the compare script:

| parameter         | default | values                           |
|-------------------|---------|----------------------------------|
| --o               | text    | json, text                       |
| -v                | off     | on                               | 
| --v               |         | npass, nfail, atest, rtest, passfail, failpass |

Example:
1. *$ bsf compare hs-gcc-baremetal-qemu 2020.09:2021.03*
2. *$ bsf compare hs-gcc-baremetal-qemu 2020.09:2021.03 -v*
3. *$ bsf compare hs-gcc-baremetal-qemu 2020.09:2021.03 --v npass* -->