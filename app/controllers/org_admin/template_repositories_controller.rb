# frozen_string_literal: true

module OrgAdmin
    # Controller that handles limiting available repositories to admin chosen repsitories
    class TemplateRepositoriesController < ApplicationController
        #include Templates_RepsitoriesMethod
        def list
            @repositories = TemplateRepository.all
        end
        def show
            @template = TemplateRepository.find(params[:id])
            if Repositories.where(:template_id => template.id).passed.exists?
            
            end

        end
        # POST /org_admin/templates/:template_id/TemplateRepository
        def new
            @template = TemplateRepository.new
        end
    
        def create
            @template = TemplateRepository.new(templates_repositories_params)
             
            if @template.save
               redirect_to :action => 'list'
            else
               @repositories = TemplateRepository.all
               render :action => 'new'
            end  
        end
        def update
            @template = TemplateRepository.find(params[:id])
            
            if @template.update_attributes(templates_repositories_params)
               redirect_to :action => 'show', :id => @template
            else
               @repositories = TemplateRepository.all
               render :action => 'edit'
            end
         end
         def edit
         end
         def delete
            TemplateRepository.find(params[:id]).destroy
            redirect_to :action => 'list'
         end
        def templates_repositories_params
            # While this is working as-is we should consider folding these into
            # the template: :links context.
            params.require(:templates_repositories).permit(:repository_id, template_id)
        end
    end
end