# freeze_string_literal: true

# Delete a group attachment from turn it in
class TiiActionDeleteGroupAttachment < TiiAction
  def run
    group_attachment_id = params[:group_attachment_id]
    group_id = params[:group_id]

    unless group_attachment_id.present? && group_id.present?
      save_and_log_custom_error "Group Attachment id or Group id does not exist - cannot delete group attachment"
      return
    end

    exec_tca_call "Deleting Group Attachment from Turn It In" do
      TCAClient::GroupsApi.new.delete_group_attachment(
        TurnItIn.x_turnitin_integration_name,
        TurnItIn.x_turnitin_integration_version,
        group_id,
        group_attachment_id
      )

      self.complete = save
      save
    end
  rescue TCAClient::ApiError => e
    handle_error e, [
      { code: 404, message: 'Group Attachment not found in delete GroupAttachment' },
      { code: 409, message: 'Group Attachment is in an error state' }
    ]
    false
  end
end
