#################################################################################
#db migrations
class CreateAssembliesAndParts < ActiveRecord::Migration
  def change
    create_table :user do |t|
      t.string :name
    end

    create_table :role do |t|
      t.string :role
    end

    create_table :user_roles, id: false do |t|
      t.belongs_to :user
      t.belongs_to :role
    end

    create_table :action do |t|
      t.string :name
    end

    create_table :user_action_permission do |t|
      t.belongs_to :user
      t.belongs_to :action
      t.integer :permission
   end

    create_table :role_action_permission do |t|
      t.belongs_to :role
      t.belongs_to :action
      t.integer :permission
    end
  end
end

#########################################################################################
# models
class User < ApplicationRecord
	has_and_belongs_to_many :roles
	has_many :user_action_permissions
end

class Role < ApplicationRecord
	has_and_belongs_to_many :users
	has_many :role_action_permisions
end

class Action < ApplicationRecord
	has_many :user_action_permissions
	has_many :role_action_permisions
end

class UserActionPermission < ApplicationRecord
	belongs_to :user
	belongs_to :action

	enum permission: {READ: 0, WRITE: 1}
end

class RoleActionPermission < ApplicationRecord
	belongs_to :role
	belongs_to :action

	enum permission: {READ: 0, WRITE: 1}
end


############################################################################################
# permissions module
module Permissions

	def check_permission(action, user)
		#returns true if it is write permission either user or group
		UserActionPermission.where(action: action, user: user)
			.any?{ |perm| perm.permission == :WRITE } || 
			RoleActionPermission.where(action: action, role: user.roles)
			.any?{ |perm| perm.permission == :WRITE 
	end

	def grant_user_permission(action, user, permission)
		UserActionPermission.create_with(permission: permission)
			.find_or_create_by(user: user, action: action)
	end

	def grant_role_permission(action, role_name, permission)
		role = Role.find_or_create_by(name: role_name)
		UserRole.find_or_create_by(role: role)
		RoleActionPermission.create_with(permission: permission)
			.find_or_create_by(role: role, action: action)
	end
end
