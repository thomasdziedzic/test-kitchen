# -*- encoding: utf-8 -*-
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "kitchen"
require "kitchen/version"
require "kitchen/transport/exec"

module Kitchen
  module Driver
    # Simple driver that runs commands locally. As with the proxy driver, this
    # has no isolation in general.
    class Exec < Kitchen::Driver::Base
      plugin_version Kitchen::VERSION

      default_config :reset_command, nil

      no_parallel_for :create, :destroy

      def finalize_config!(instance)
        super.tap do
          instance.transport = Kitchen::Transport::Exec.new
        end
      end

      # (see Base#create)
      def create(state)
        reset_instance(state)
      end

      # (see Base#destroy)
      def destroy(state)
        return if state[:hostname].nil?
        reset_instance(state)
        state.delete(:hostname)
      end

      private

      # Resets the non-Kitchen managed instance using by issuing a command
      # over SSH.
      #
      # @param state [Hash] the state hash
      # @api private
      def reset_instance(state)
        if cmd = config[:reset_command]
          info("Resetting instance state with command: #{cmd}")
          ssh(build_ssh_args(state), cmd)
        end
      end
    end
  end
end
