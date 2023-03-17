# frozen_string_literal: true

module OrgAdmin
    # Controller that handles limiting available repositories to admin chosen repsitories
    class TemplatesRepositoriesController < ApplicationController
      include Versionable
        def set_templates_repositories
        @templates_repositories = Templates_Repositories.find(params[:id])
        end

      # POST /org_admin/templates/:template_id/phases/:phase_id/versions
        def new
            @templates_repositories = Article.new
        end
    
        def create
            @templates_repositories = Templates_Repositories.create(templates_repositories_params)
            if @templates_repositories.save
                flash[:notice] = "Preferences successfully saved."
                redirect_to articles_path
            else
                render :new
            end
        end
        
        def templates_repositories_params
            # While this is working as-is we should consider folding these into
            # the template: :links context.
            params.require(:template).permit(:repositories)
        end
  
    end
end