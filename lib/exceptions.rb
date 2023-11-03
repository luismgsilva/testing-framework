module Ex
    class InvalidOptionException < StandardError
        def initialize(option)
            super("bsf: Option Invalid #{option}")
        end
    end
    class ProcessTerminatedByUserException < StandardError
        def initialize
            super("bsf: Got a INT signal, interrupted by user")
        end
    end
    class NotBSFDirectoryException < StandardError
        def initialize
            super "bsf: Not a bsf environment"
        end
    end
    class AlreadyBSFDirectoryException < StandardError
        def initialize
            super "bsf: Already a bsf environment"
        end
    end
    class InvalidConfigFileException < StandardError
        def initialize
            super "bsf: Invalid configuration file"
        end
    end
    class InvalidFragConfigFileException < StandardError
        def initialize(frag)
            super "bsf: Invalid fragment configuration file - #{frag}"
        end
    end
    class PathMustContainConfigFileException < StandardError
        def initialize
            super "bsf: Path must contain config.json file"
        end
    end
    class CouldNotCopyFilesException < StandardError
        def initialize
            super "bsf: Could not copy files"
        end
    end
    class MustInitializeGitRepoException < StandardError
        def initialize
            super "bsf: Must initialize git repository: `bsf git init`"
        end
    end
    class CouldNotGetLockException < StandardError
        def initialize
            super "bsf: Could not get lock"
        end
    end
    class TargetNotInSystemException < StandardError
        def initialize(target)
            super "bsf: Target not in system - #{target}"
        end
    end
    class ReportNotSupportedException < StandardError
        def initialize
            super "bsf: Report not supported"
        end
    end
    class CommitIdNotValidException < StandardError
        def initialize(commit_id)
            super "bsf: Commit Id not valid - #{commit_id}"
        end
    end
    class TaskNotExecutedException < StandardError
        def initialize(task)
            super "bsf: Task not executed - #{task}"
        end
    end
    class TaskNotExecutedException < StandardError
        def initialize
            super "bsf: Task not executed"
        end
    end
    class TargetNotSpecifiedException < StandardError
        def initialize
            super "bsf: Target not specified"
        end
    end
    class AgregatorNotSupportedException < StandardError
        def initialize
            super "bsf: Agregator not supported"
        end
    end
    class TaskNotFoundException < StandardError
        def initialize(task)
            super "bsf: Task not found - #{task}"
        end
    end
    class PublishCommandException < StandardError
        def initialize(command)
            super "bsf: Publish command - #{command}"
        end
    end
    class StatusFileDoesNotExistsException < StandardError
        def initialize
            super "bsf: Nothing executed yet"
        end
    end
    class NoSourcesClonedYetException < StandardError
        def initialize
            super "bsf: No sources cloned yet"
        end
    end
    class NotEditableVariableException < StandardError
        def initialize
            super "bsf: Not a editable variable"
        end
    end
    class NotAVariableException < StandardError
        def initialize(variable)
            super "bsf: Not a variable - #{variable}"
        end
    end
    class InputVariableNotSetException < StandardError
        def initialize(variable)
            super "bsf: Input variable not set - #{variable}"
        end
    end
    class NotRegisteredSourceException < StandardError
        def initialize(source)
            super("bsf: Not a registered Source: #{source}")
        end
    end
    class NothingToCloneException < StandardError
        def initialize
            super("bsf: Nothing to clone.")
        end
    end

    class ComparatorNotFoundForTargetException < StandardError
        def initialize(target)
            super("bsf: Target comparator not found - #{target}")
        end
    end

    class DirectoryDoesNotExistException < StandardError
        def initialize(path)
            super("bsf: Directory does not exist - #{path}")
        end
    end

    class MissingArgumentException < StandardError
        def initialize(arg)
            super("bsf: Missing argument - #{arg}. See 'bsf'.")
        end
    end

    class InvalidCommandException < StandardError
        def initialize(command)
            #super("bsf: Invalid command - #{command}")
            super("bsf: '#{command}' is not a bsf command. See 'bsf'.")
        end
    end

    class API_TEMP < StandardError
        def initialize(msg)
            super(msg)
        end
    end
end
