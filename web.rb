require 'sinatra'
require 'rest-client'
require 'json'
require 'oauth'

# the name of the github repository where the project and issues are located
GITHUB_REPO = 'doerfli/github-project-labels'
# the name of the project to track
PROJECT_NAME = 'Sample Project'
# the secret to verify the source of the request
SECRET = ''

GITHUB_API_BASE_URL = 'https://api.github.com'
GITHUB_LABELS_URL = "#{GITHUB_API_BASE_URL}/repos/#{GITHUB_REPO}/labels"
GITHUB_PROJECTS_URL = "#{GITHUB_API_BASE_URL}/repos/#{GITHUB_REPO}/projects"

before do
  request.body.rewind
  @request_payload = JSON.parse request.body.read
end

post '/card_moved' do
  puts @request_payload
  return 'Card is note - no labels to change' if @request_payload['project_card']['note'] != nil
  return 'Action was not move' if @request_payload['action'] != 'moved'

  labels = {}
  response = RestClient.get(GITHUB_LABELS_URL, :Authorization => "token #{ENV['ACCESS_TOKEN']}")
  labels_json = JSON.parse(response)
  labels_json.each { |lab|
    labels[lab['name']] = {
      #name: lab['name'],
      id: lab['id'],
      # url: lab['url']
    }
  }
  puts labels

  projects = {}
  response = RestClient.get(GITHUB_PROJECTS_URL, :accept => 'application/vnd.github.inertia-preview+json', :Authorization => "token #{ENV['ACCESS_TOKEN']}")
  projects_json = JSON.parse(response)
  projects_json.each { |prj|
    # puts prj
    projects[prj['name']] = prj['id']
  }

  columns = {}
  columns_url = "#{GITHUB_API_BASE_URL}/projects/#{projects[PROJECT_NAME]}/columns"
  response = RestClient.get(columns_url, :accept => 'application/vnd.github.inertia-preview+json', :Authorization => "token #{ENV['ACCESS_TOKEN']}")
  columns_json = JSON.parse(response)
  columns_json.each { |col|
    # puts col
    columns[col['id']] = col['name']
  }
  puts columns

  issue_id = @request_payload['project_card']['id']
  column_id_from = @request_payload['changes']['column_id']['from']
  column_id_to = @request_payload['project_card']['column_id']
  label_remove = columns[column_id_from]
  label_add = columns[column_id_to]

  puts "issue #{issue_id}  labels -#{label_remove} +#{label_add}"
  card_content_url = @request_payload['project_card']['content_url']

  label_remove_url = "#{card_content_url}/labels/#{URI.escape(label_remove)}"
  puts label_remove_url
  response = RestClient.delete(label_remove_url, :Authorization => "token #{ENV['ACCESS_TOKEN']}")

  puts "label removed: #{label_remove}"

  label_add_url = "#{card_content_url}/labels"
  puts label_add_url
  response = RestClient.post(label_add_url, [label_add].to_json, :content_type => :json, :accept => 'application/vnd.github.inertia-preview+json', :Authorization => "token #{ENV['ACCESS_TOKEN']}")

  puts "label added: #{label_add}"

  "issue #{issue_id}  labels -#{label_remove} +#{label_add}"
end
