module Ex
    class InvalidOptionException < StandardError
        def initialize(option)
            super("ERROR: Option Invalid #{option}")
        end
    end
    class ProcessTerminatedByUserException < StandardError
        def initialize
            super("ERROR: Process terminated by User")
        end
    end
    class NotBSFDirectoryException < StandardError
        def initialize
            super "ERROR: Not a bsf environment"
        end
    end
    class AlreadyBSFDirectoryException < StandardError
        def initialize
            super "ERROR: Already a bsf environment"
        end
    end
    class InvalidConfigFileException < StandardError
        def initialize
            super "ERROR: Invalid configuration file"
        end
    end
    class PathMustContainConfigFileException < StandardError
        def initialize
            super "ERROR: Path must contain config.json file"
        end
    end
    class CouldNotCopyFilesException < StandardError
        def initialize
            super "ERROR: Could not copy files"
        end
    end
    class MustInitializeGitRepoException < StandardError
        def initialize
            super "ERROR: Must initialize git repository: `bsf git init`"
        end
    end
    class CouldNotGetLockException < StandardError
        def initialize
            super "ERROR: Could not get lock"
        end
    end
    class TargetNotInSystemException < StandardError
        def initialize(target)
            super "ERROR: Target not in system - #{target}"
        end
    end
    class ReportNotSupportedException < StandardError
        def initialize
            super "ERROR: Report not supported"
        end
    end
    class CommitIdNotValidException < StandardError
        def initialize(commit_id)
            super "ERROR: Commit Id not valid - #{commit_id}"
        end
    end
    class TaskNotExecutedException < StandardError
        def initialize(task)
            super "ERROR: Task not executed - #{task}"
        end
    end
    class TargetNotSpecifiedException < StandardError
        def initialize
            super "ERROR: Target not specified"
        end
    end
    class AgregatorNotSupportedException < StandardError
        def initialize
            super "ERROR: Agregator not supported"
        end
    end
    class TaskNotFoundException < StandardError
        def initialize(task)
            super "ERROR: Task not found - #{task}"
        end
    end
    class PublishCommandException < StandardError
        def initialize(command)
            super "ERROR: Publish command - #{command}"
        end
    end
    class StatusFileDoesNotExistsException < StandardError
        def initialize
            super "ERROR: Nothing executed yet"
        end
    end
    class NoSourcesClonedYetException < StandardError
        def initialize
            super "ERROR: No sources cloned yet"
        end
    end
    class NotEditableVariableException < StandardError
        def initialize
            super "ERROR: Not a editable variable"
        end
    end
    class NotAVariableException < StandardError
        def initialize(variable)
            super "ERROR: Not a variable - #{variable}"
        end
    end
    class InputVariableNotSetException < StandardError
        def initialize(variable)
            super "ERROR: Input variable not set - #{variable}"
        end
    end
    class NotRegisteredSourceException < StandardError
        def initialize(source)
            super("ERROR: Not a registered Source: #{source}")
        end
    end
    class NothingToCloneException < StandardError
        def initialize
            super("ERROR: Nothing to clone.")
        end
    end

    class ComparatorNotFoundForTargetException < StandardError
        def initialize(target)
            super("ERROR: Target comparator not found - #{target}")
        end
    end
    class API_TEMP < StandardError
        def initialize(msg)
            super(msg)
        end
    end
end