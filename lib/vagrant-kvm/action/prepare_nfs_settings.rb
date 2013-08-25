module VagrantPlugins
  module ProviderKvm
    module Action
      class PrepareNFSSettings
        def initialize(app,env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::action::vm::nfs")
        end

        def call(env)
          @app.call(env)

          using_nfs = false
          env[:machine].config.vm.synced_folders.each do |id, opts|
            if opts[:nfs]
              using_nfs = true
              break
            end
          end

          if using_nfs
            @logger.info("Using NFS, preparing NFS settings by reading host IP and machine IP")
            env[:nfs_host_ip]    = read_host_ip(env)
            env[:nfs_machine_ip] = read_machine_ip(env)

            raise Vagrant::Errors::NFSNoHostonlyNetwork if !env[:nfs_machine_ip]
          end
        end

        # Returns the IP address of the first host only network adapter
        #
        # @return [String]
        def read_host_ip(env)
          ip = read_machine_ip(env)
          if ip
            base_ip = ip.split(".")
            base_ip[3] = "1"
            return base_ip.join(".")
          end

          nil
        end

        # Returns the IP address of the guest by looking at the first
        # enabled host only network.
        #
        # @return [String]
        def read_machine_ip(env)
          return env[:machine_ip] if env[:machine_ip]
          env[:machine].config.vm.networks.each do |type, options|
            if type == :private_network && options[:ip].is_a?(String)
              return options[:ip]
            end
          end

          nil
        end
      end
    end
  end
end
