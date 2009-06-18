# This patch's original author is edavis10.
# This patch is downloaded from his redmine-budget-plugin.
# http://github.com/edavis10/redmine-budget-plugin/tree/master
#
require_dependency 'attachment'

# Patches Redmine's Attachments dynamically. Adds a relationship
# Attachment +belongs_to+ to Faq
module AttachmentPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      belongs_to :faq

    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end
