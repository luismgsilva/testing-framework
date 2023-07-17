module Diff

  def diff(hash1, hash2)
    if check_commit_id(hash1)
      raise Ex::CommitIdNotValidException
    end
    if check_commit_id(hash2)
      raise Ex::CommitIdNotValidException
    end

    hash1 = JSON.parse(`cd #{DirManager.get_framework_path} ; 
              git log -n 1 --pretty=format:%s #{hash1}`)
    hash2 = JSON.parse(`cd #{DirManager.get_framework_path} ; 
              git log -n 1 --pretty=format:%s #{hash2}`)
    return JSON.pretty_generate GitManager.diff(hash1, hash2)
  end

  def diff(hash1, hash2)
    (hash1.keys | hash2.keys).each_with_object({}) do |k, r|
      if hash1[k] != hash2[k]
        if hash1[k].is_a?(Hash) && hash2[k].is_a?(Hash)
          r[k] = diff(hash1[k], hash2[k])
        else
          r[k] = [hash1[k], hash2[k]]
        end
      end
      r
    end
  end
end