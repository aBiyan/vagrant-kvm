module VagrantPlugins
  module ProviderKvm
    module Action
      class ForcedHalt
        def initialize(app, env)
          @app = app
        end

        def call(env)
          current_state = env[:machine].state.id
          if current_state == :running
            env[:ui].info I18n.t("vagrant.actions.vm.halt.force")
            env[:machine].provider.driver.halt
          end

          @app.call(env)
        end
      end
    end
  end
end
