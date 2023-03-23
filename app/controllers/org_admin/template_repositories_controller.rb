# frozen_string_literal: true

module OrgAdmin
	# Controller that handles limiting available repositories to admin chosen repsitories
	class TemplateRepositoriesController < ApplicationController
		# POST /org_admin/templates/:template_id/TemplateRepository
		def new
			template = Template.includes(:phases).find(params[:template_id])
			# authorize phase
			local_referrer = (request.referer.presence || org_admin_templates_path)
			render('/org_admin/templates/container',
				locals: {
					partial_path: 'new',
					template: template,
					referrer: local_referrer
				})
		end

		def templates_repositories_params
			# While this is working as-is we should consider folding these into
			# the template: :links context.
			params.require(:templates_repositories).permit(:repository_id, template_id)
		end
	end
end