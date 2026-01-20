use evm_processor::{BasicAuthCredentials, LogosBlockchainDa, Processor};
use futures::TryStreamExt as _;
use reth::{
    api::{FullNodeTypes, NodePrimitives, NodeTypes},
    cli::Cli,
};
use reth_ethereum::{
    exex::{ExExContext, ExExEvent, ExExNotification},
    node::{EthereumNode, api::FullNodeComponents},
};
use reth_tracing::tracing::info;

const TESTNET_EXECUTOR: &str = "https://devnet.blockchain.logos.co/node/3/";

async fn process_blocks<Node: FullNodeComponents>(
    mut ctx: ExExContext<Node>,
    mut processor: Processor,
) -> eyre::Result<()>
where
    <<Node as FullNodeTypes>::Types as NodeTypes>::Primitives:
        NodePrimitives<Block = reth_ethereum::Block>,
{
    while let Some(notification) = ctx.notifications.try_next().await? {
        let ExExNotification::ChainCommitted { new } = &notification else {
            continue;
        };
        info!(committed_chain = ?new.range(), "Received commit");
        processor
            .process_blocks(
                new.inner()
                    .0
                    .clone()
                    .into_blocks()
                    .map(reth_ethereum::primitives::RecoveredBlock::into_block),
            )
            .await;

        ctx.events
            .send(ExExEvent::FinishedHeight(new.tip().num_hash()))
            .unwrap();
    }

    Ok(())
}

fn main() -> eyre::Result<()> {
    Cli::try_parse_args_from([
        "reth",
        "node",
        "--datadir=/tmp/reth-dev/",
        "--dev",
        "--dev.block-time=2s",
        "--http.addr=0.0.0.0",
    ])
    .unwrap()
    .run(|builder, _| {
        Box::pin(async move {
            let url = std::env::var("LB_EXECUTOR").unwrap_or(TESTNET_EXECUTOR.to_string());
            let user = std::env::var("LB_USER").unwrap_or_default();
            let password = std::env::var("LB_PASSWORD").unwrap_or_default();
            let da = LogosBlockchainDa::new(
                BasicAuthCredentials::new(user, Some(password)),
                url::Url::parse(&url).unwrap(),
            );
            let processor = Processor::new(da);
            let handle = Box::pin(
                builder
                    .node(EthereumNode::default())
                    .install_exex("process-block", async move |ctx| {
                        Ok(process_blocks(ctx, processor))
                    })
                    .launch(),
            )
            .await?;

            handle.wait_for_node_exit().await
        })
    })
}
