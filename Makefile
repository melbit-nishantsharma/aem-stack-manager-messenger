version ?= 1.1.0

# development targets

ci: clean deps lint package

clean:
	rm -rf logs
	rm -f *.retry

deps:
	pip install -r requirements.txt

lint:
	shellcheck send-message.sh
	ansible-playbook -vvv send-message.yaml --syntax-check


# send message targets

promote-author:
	./send-message.sh "$(stack_prefix)" "$(topic_config_file)" "$(message_config_file)"


deploy-artifacts:
	./send-message.sh "$(stack_prefix)" "$(topic_config_file)" "$(message_config_file)" "$(details)"

deploy-artifact:
	./send-message.sh "$(stack_prefix)" "$(topic_config_file)" "$(message_config_file)" "$(details)"

export-package:
	echo package_filter=$(package_filter)
	./send-message.sh "$(stack_prefix)" "$(topic_config_file)" "$(message_config_file)" "$(details)"

import-package:
	./send-message.sh "$(stack_prefix)" "$(topic_config_file)" "$(message_config_file)" "$(details)"

offline-snapshot:
	./send-message.sh "$(stack_prefix)" "$(topic_config_file)" "$(message_config_file)"


offline-compaction-snapshot:
	./send-message.sh "$(stack_prefix)" "$(topic_config_file)" "$(message_config_file)"


package:
	rm -rf stage
	mkdir -p stage
	tar \
	    --exclude='.git*' \
	    --exclude='.tmp*' \
	    --exclude='stage*' \
	    --exclude='.idea*' \
	    --exclude='.DS_Store*' \
	    --exclude='logs*' \
	    --exclude='*.retry' \
	    --exclude='*.iml' \
	    -cvf \
	    stage/aem-stack-manager-messenger-$(version).tar ./
	gzip stage/aem-stack-manager-messenger-$(version).tar

git-archive:
	rm -rf stage
	mkdir -p stage
	git archive --format=tar.gz --prefix=aem-stack-manager-messenger-$(version)/ HEAD -o stage/aem-stack-manager-messenger-$(version).tar.gz

.PHONY: promote-author offline-snapshot deploy-artifacts deploy-artifact ci clean deps lint export-package import-package package git-archive offline-compaction-snapshot
