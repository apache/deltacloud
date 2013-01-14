# This is a copy of code that has been submitted upstream
# https://github.com/rackspace/ruby-cloudservers/pull/22
#
# Once the pull request is merged we can remove this patch
# Also see https://issues.apache.org/jira/browse/DTACLOUD-319

module CloudServers
  class Connection

    def list_servers_detail(options = {})
      anti_cache_param="cacheid=#{Time.now.to_i}"
      path = CloudServers.paginate(options).empty? ? "#{svrmgmtpath}/servers/detail?#{anti_cache_param}" : "#{svrmgmtpath}/servers/detail?#{CloudServers.paginate(options)}&#{anti_cache_param}"
      response = csreq("GET",svrmgmthost,path,svrmgmtport,svrmgmtscheme)
      CloudServers::Exception.raise_exception(response) unless response.code.match(/^20.$/)
      CloudServers.symbolize_keys(JSON.parse(response.body)["servers"])
    end
    alias :servers_detail :list_servers_detail

  end
end
