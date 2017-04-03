class PagesController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def group
    @help = :application_group
    @back = { text: "Back to #{@application.name}", link: view_application_path(@application.slug) }
  end
  
  def page
    @help = :page
    @back = { text: "Back to #{@group.to_s.titlecase}", link: page_group_path(@application.slug, @group) }
    @examples = []
    @variants = @group == :email ? [:desktop] : [:desktop, :mobile]
    LinguaFranca.get_translation_info(@application.path).each do |key, info|
      page_info = info["#{@group}/#{@page}"] || {}
      @examples |= (page_info['indices'] || [])
    end
  end

  def preview
    @help = :page_preview
    @back = { text: "Back to #{@page.to_s.titlecase}", link: page_path(@application.slug, @group, @page) }
    @index = params[:index].to_i
    @variant = params[:variant].to_sym
    @layout = :preview
    @comments = PageComment.where({
        application_id: @application.id,
        group:   @group,
        page:    @page,
        index:   @index,
        variant: @variant})

    @examples = []
    @example_index = 0
    @pages.each do |group, pages|
      variants = group == 'email' ? [:desktop] : [:desktop, :mobile]
      pages.each do |page|
        variants.each do |variant|
          @example_index = @examples.length if @group.to_s == group && @page.to_s == page && @variant == variant
          @examples << [@application.slug, group, page, 0, variant]
        end
      end
    end
    @prev_example = @example_index - 1
    @next_example = @example_index + 1

    @prev_example = @examples.length - 1 if @prev_example < 0
    @next_example = 0 if @next_example >= @examples.length

    @is_watching = current_user.following_page?(@application.id, @group, @page, @index, @variant)
  end

  def comment
    PageComment.create({
        application_id: @application.id,
        comment: params[:comment],
        group:   @group,
        page:    @page,
        index:   params[:index],
        variant: params[:variant],
        user_id: current_user.id
      })
    current_user.follow_page(@application.id, @group, @page, params[:index], params[:variant])

    followers = PageFollower.where(application_id: @application.id, group: @group, page: @page, index: params[:index], variant: params[:variant]) + PageFollower.where(application_id: @application.id, group: @group, page: '-') + PageFollower.where(application_id: @application.id, group: '-', page: '-')
    followers.map(&:user_id).uniq.each do |user_id|
      unless user_id == current_user.id
        UserMailer.page_comment(User.find(user_id), current_user, params[:comment], "#{@page.to_s.titlecase} #{@group == 'email' ? 'email' : 'page'}", page_preview_url(@application.slug, @group, @page, params[:index], params[:variant])).deliver!
      end
    end

    redirect_to page_preview_path
  end

end