# encoding: UTF-8
#=============================================================================
# Contents   : AscConfig
# Author     : Ascend Corp
# Since      : 2016/04/14        1.0        
#=============================================================================

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
        @data[:local_path_inbound] = arg + "/schedule"
        @data[:local_log_path] = arg + "/log"
    end

    def remote_path(arg)
        @data[__method__] = arg
        @data[:remote_path_inbound] = arg + "/var_in"
    end

    def call_module_path_inbound(arg)
        @data[__method__] = arg
    end

    def ques_voice(arg)
        @data[__method__] = arg
    end

    def ques_basic(arg)
        @data[__method__] = arg
    end

    def ques_auth(arg)
        @data[__method__] = arg
    end

    def ques_tel(arg)
        @data[__method__] = arg
    end

    def ques_trans(arg)
        @data[__method__] = arg
    end

    def ques_record(arg)
        @data[__method__] = arg
    end

    def ques_count(arg)
        @data[__method__] = arg
    end

    def ques_end(arg)
        @data[__method__] = arg
    end

    def ques_timeout(arg)
        @data[__method__] = arg
    end

    def ques_auth_character(arg)
        @data[__method__] = arg
    end

    def ques_inbound_collation(arg)
        @data[__method__] = arg
    end

    def ques_inbound_sms_input(arg)
        @data[__method__] = arg
    end

    def ques_property(arg)
        @data[__method__] = arg
    end

    def ques_property_search(arg)
        @data[__method__] = arg
    end

    def ques_fax(arg)
        @data[__method__] = arg
    end

    def ques_inbound_sms(arg)
        @data[__method__] = arg
    end

    def server_inbound_type(arg)
        @data[__method__] = arg
    end

    def ai_user(arg)
        @data[__method__] = arg
    end

    def ai_pass(arg)
        @data[__method__] = arg
    end

    def ai_speaker(arg)
        @data[__method__] = arg
    end

    def status_inbound_message(arg)
        @data[__method__] = arg
    end

    def status_inbound_busy(arg)
        @data[__method__] = arg
    end

    def status_inbound_end(arg)
        @data[__method__] = arg
    end

    def extensions_conf_path(arg)
        @data[__method__] = arg
    end

    def fax_api_url(arg)
        @data[__method__] = arg
    end

    def fax_api_token(arg)
        @data[__method__] = arg
    end

    def property_search_max(arg)
        @data[__method__] = arg
    end

    def property_synth_url(arg)
        @data[__method__] = arg
    end

    def property_synth_customer_id(arg)
        @data[__method__] = arg
    end

    def property_synth_user_id(arg)
        @data[__method__] = arg
    end

    def property_synth_user_password(arg)
        @data[__method__] = arg
    end

    def getData()
        return @data
    end
end
