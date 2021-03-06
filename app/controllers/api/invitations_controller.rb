class API::InvitationsController < API::RestfulController
  def create
    load_and_authorize :group, :invite_people
    @invitations = InvitationService.invite_to_group(recipient_emails: email_addresses,
                                                     group: @group,
                                                     inviter: current_user,
                                                     message: invitation_form_params[:message])
    respond_with_collection
  end

  def pending
    load_and_authorize :group, :view_pending_invitations
    @invitations = page_collection(@group.invitations.pending)
    respond_with_collection
  end

  def shareable
    load_and_authorize :group, :view_shareable_invitation
    @invitations = [InvitationService.shareable_invitation_for(@group)]
    respond_with_collection
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    InvitationService.cancel(invitation: @invitation, actor: current_user)
    respond_with_resource
  end

  private

  def invitation_form_params
    params.require(:invitation_form)
  end

  def email_addresses
    invitation_form_params[:emails].scan(/[^\s<,]+?@[^>,\s]+/).take(100)
  end

end
