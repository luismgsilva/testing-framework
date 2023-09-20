module Diff

  def self.diff(hash1, hash2)
    Helper.check_commit_id(hash1)
    Helper.check_commit_id(hash2)

    cmd = "git -C #{DirManager.get_framework_path} log -n 1 --pretty=format:%s #{hash1}"
    hash1 = JSON.parse(Helper.return_execute(cmd))

    cmd = "git -C #{DirManager.get_framework_path} log -n 1 --pretty=format:%s #{hash2}"
    hash2 = JSON.parse(Helper.return_execute(cmd))

    return JSON.pretty_generate(diff1(hash1, hash2))
  end

  def self.diff1(hash1, hash2)
    (hash1.keys | hash2.keys).each_with_object({}) do |k, r|
      if hash1[k] != hash2[k]
        if hash1[k].is_a?(Hash) && hash2[k].is_a?(Hash)
          r[k] = diff1(hash1[k], hash2[k])
        else
          r[k] = [hash1[k], hash2[k]]
        end
      end
      r
    end
  end
end
