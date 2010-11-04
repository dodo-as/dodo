class ReportsController < ApplicationController
  
  def index
    @periods = Period.all(:limit=>20)
    @units = Unit.all(:limit=>20)
    @projects = Project.all(:limit=>20)
    @journal_types = JournalType.all(:limit=>20)
  end
  
end
