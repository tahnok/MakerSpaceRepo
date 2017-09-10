class CreateGngCategoriesForCrpRepos < ActiveRecord::Migration
  def up
    gng2101 = CategoryOption.new(name: 'GNG2101')
    gng2101.save
    gng1103 = CategoryOption.new(name: 'GNG1103')
    gng1103.save
    other_projects =  CategoryOption.find_by(name: 'Other Projects')
    Category.where(name: "Course-related Projects").each do |category|
      course = category.repository.title.upcase.gsub(/[^0-9A-Za-z]/, '')[0..6]
      if course == 'GNG2101'
        repo_gng_cat = Category.new(repository_id: category.repository.id, name: course, category_option_id: gng2101.id)
        repo_gng_cat.save
        category.destroy
      elsif course == 'GNG1103'
        repo_gng_cat = Category.new(repository_id: category.repository.id, name: course, category_option_id: gng1103.id)
        repo_gng_cat.save
        category.destroy
      else
        repo_gng_cat = Category.new(repository_id: category.repository.id, name: 'Other Projects', category_option_id: other_projects.id)
        repo_gng_cat.save
        category.destroy
      end
    end
  end
end
