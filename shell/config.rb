class AscConfig
    def initialize
        @data={}
    end

    def database_ip(arg)
        @data[__method__] = arg
    end

    def database_id(arg)
        @data[__method__] = arg
    end

    def database_pass(arg)
        @data[__method__] = arg
    end

    def database_schema(arg)
        @data[__method__] = arg
    end

    def local_path(arg)
        @data[__method__] = arg
        @data[:local_schedule] = arg + "schedule/"
    end
	
	def remote_path(arg)
        @data[__method__] = arg
    end
	
	def aserver_name(arg)
        @data[__method__] = arg
    end

    def ascallsrv_port(arg)
        @data[__method__] = arg
    end

    def local_out_schedule_path(arg)
        @data[__method__] = arg
    end

    def local_in_schedule_path(arg)
        @data[__method__] = arg
    end

    def remote_out_schedule_path(arg)
        @data[__method__] = arg
    end

    def remote_in_schedule_path(arg)
        @data[__method__] = arg
    end

    def local_out_schedule_backup_path(arg)
        @data[__method__] = arg
    end

    def local_in_schedule_backup_path(arg)
        @data[__method__] = arg
    end

    def remote_out_schedule_backup_path(arg)
        @data[__method__] = arg
    end

    def remote_in_schedule_backup_path(arg)
        @data[__method__] = arg
    end

    def getData()
        return @data
    end
end
